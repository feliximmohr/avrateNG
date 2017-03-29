#!/usr/bin/env python3
import os
import sys
import argparse
import json
import threading
import webbrowser
import time
import datetime

# load libs from lib directory
import loader
from log import *
from system import *

import bottle
from bottle import Bottle
from bottle import auth_basic
from bottle import route
from bottle import run
from bottle import install
from bottle import template
from bottle import request
from bottle import redirect
from bottle import response
from bottle import error
from bottle import static_file
from bottle_sqlite import SQLitePlugin
from bottle_config import ConfigPlugin

# TODO: Some kind of wait screen while video is played (mobile)

def check_credentials(username, password):
    config = ConfigPlugin._config
    validName = config["http_user_name"]
    validPassword = config["http_user_password"]
    return password == validPassword and username == validName


def play(config, video_index):
    video = config["playlist"][video_index]
    lInfo("play {}".format(video))
    shell_call(config["player"].format(filename=video))


@route('/')  # Welcome screen
@auth_basic(check_credentials)
def welcome(db, config):
    # for every new start ("/"): user_id (cookie) is incremented by 1

    if not db.execute("SELECT * FROM sqlite_master WHERE type='table' AND name='ratings'").fetchone():
        user_id = 1 # if ratings table does not exist: first user_id = 1
    else:
        user_id = int(db.execute('SELECT max(user_ID) from ratings').fetchone()[0]) + 1  # new user_ID is always old (highest) user_ID+1
    response.set_cookie("user_id",str(user_id),path="/")

    # initialize session_state variable (throws error when refreshing the page or going back)
    response.set_cookie("session_state","0",path="/")

    return template("templates/welcome.tpl", title="AvRate++", user_id=user_id)


@route('/rate/<video_index>')  # Rating screen with video_index as variable
@auth_basic(check_credentials)
def rate(db, config, video_index):

    video_index = int(video_index)
    user_id = int(request.get_cookie("user_id"))
    session_state = int(request.get_cookie("session_state"))

    if video_index == session_state:
        play_video = 1
    else:
        play_video = 0

    # play video only on first visit
    if play_video == 1:
        play(config, video_index)
        # play just one time
        play_video = 0
        session_state = session_state + 1
        response.set_cookie("session_state",str(session_state),path="/")


    return template("templates/rate1.tpl", title="AvRate++", video_index=video_index, video_count=len(config["playlist"]), user_id=user_id)


@route('/about') # About section
@auth_basic(check_credentials)
def about():
    return template("templates/about.tpl", title="AvRate++")


@route('/info') # User Info screen
@auth_basic(check_credentials)
def info():
    return template("templates/demographicInfo.tpl", title="AvRate++")


@route('/finish') # Finish screen
@auth_basic(check_credentials)
def info():
    return template("templates/finish.tpl", title="AvRate++")



@route('/statistics')
@auth_basic(check_credentials)
def statistics(db):
    # TODO: implement a short diagram of stored ratings, e.g. using http://www.chartjs.org/
    #  or https://developers.google.com/chart/

    # e.g. average rating per video file with confidence intervalls, or something else :)

    # at first get the data in the fitting form:
    # ...turns out to be not so easy -> first start would be JSON objects of data...

    return template("templates/statistics.tpl", title="AvRate++",input_data=input_data)


@route('/save_rating', method='POST')
@auth_basic(check_credentials)
def saveRating(db,config):  # save rating for watched video
    # store : request.POST as json string in database
    timestamp = str(datetime.datetime.fromtimestamp(int(time.time())).strftime('%Y-%m-%d %H:%M:%S'))  # define structure of timestamp
    video_index = request.query.video_index  # extract current video_index from query
    user_id=int(request.get_cookie("user_id"))
    # TODO: add filename of video that was played
    # TODO: maybe change storing of rating to something else than request.body.read()
    db.execute('CREATE TABLE IF NOT EXISTS ratings (user_ID, video string, rating_filled string, timestamp);')
    db.execute('INSERT INTO ratings VALUES (?,?,?,?);',(user_id, video_index, request.body.read(), timestamp))
    db.commit()

    # check if last video in playlist
    video_index = int(video_index) + 1
    if video_index > len(config["playlist"]) - 1:  # playlist over
        redirect('/info')
    else:
        redirect('/rate/' + str(video_index))  # next video


@route('/save_demographics', method='POST')
@auth_basic(check_credentials)
def saveDemographics(db, config):  # save user information (user_id is key in tables)
    user_id = int(request.get_cookie("user_id"))
    db.execute('CREATE TABLE IF NOT EXISTS info (user_ID, user data);')
    db.execute('INSERT INTO info VALUES (?,?);',(user_id, request.body.read()))
    db.commit()
    redirect('/finish')


@route('/static/<filename:path>',name='static')  # access the stylesheets
@auth_basic(check_credentials)
def server_static(filename):
    # needed for routing the static files (CSS)
    this_dir_path = os.path.dirname(os.path.abspath(__file__))
    return static_file(filename, root=this_dir_path + '/templates/static')


def server(config, host="127.0.0.1"):
    install(SQLitePlugin(dbfile='ratings.db'))
    install(ConfigPlugin(config))

    lInfo("server starting.")
    run(host=host, port=config["http_port"], debug=True, reloader=True)
    lInfo("server stopped.")


def main(params=[]):
    parser = argparse.ArgumentParser(description='avrate++', epilog="stg7 2017", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-configfilename', type=str, default="config.json", help='configuration file name')
    parser.add_argument('-playlist', type=str, default="playlist.list", help='video sequence play list')
    parser.add_argument('--standalone', action='store_true', help="run as standalone version")

    argsdict = vars(parser.parse_args())
    lInfo("read config {}".format(argsdict["configfilename"]))
    # read config file
    try:
        config = json.loads(read_file(os.path.dirname(os.path.realpath(__file__)) + "/" + argsdict["configfilename"]))
    except Exception as e:
        lError("configuration file 'config.json' is corrupt (not json conform). Error: " + str(e))
        return 1

    lInfo("read playlist {}".format(argsdict["playlist"]))
    with open(argsdict["playlist"]) as playlistfile:
        playlist = [os.path.join(*x.strip().split("/")) for x in playlistfile.readlines() if x.strip() != ""]
        config["playlist"] = playlist  # add cleaned playlist to config
        # check if each video exists
        for video in playlist:
            if not os.path.isfile(video):
                lError("'{}' is not a valid videofile, please check your playlistfile".format(video))
                return -1

    from sys import platform
    if platform == "linux" or platform == "linux2":
        config["player"] = config["player_linux"]  # override player command for linux

    if argsdict["standalone"]:
        # run server in separate thread
        server_thread = threading.Thread(target=server, args=[config])
        server_thread.start()
        # open (default) web browser
        webbrowser.open("http://127.0.0.1:{port}/".format(port=config["http_port"]), new=1, autoraise=True)
        return

    # default case: run in server mode
    server(config, host='0.0.0.0')


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
