% rebase('templates/skeleton.tpl', title=title)


<h1 class="mt-5">Background Questions</h1>
<p class="lead">Please answer the following questions before we start.</p>
<form id="questionnaire" action="/questionnaire" method="post">

  <!-- Adapted from original form developed by John Dumke and Margaret Pinson -->
<%
questions = [
    {'type': 'choice', 'question': 'What is your age?', 'qkey': 'user_age_range', 'options': ['', '< 18', '18 to 24', '25 to 29', '30 to 39', '40 to 49', '50 to 59', '60 to 69', '70+']},
    {'type': 'choice', 'question': 'What is your gender?', 'qkey': 'user_gender', 'options': ['', 'Male', 'Female', 'Diverse', 'Rather not say']},
    {'type': 'sep'},
    {'type': 'choice', 'question': 'Do you have experiences in perception tests?', 'qkey': 'user_perception_tests', 'options': ['', 'Yes', 'No']},
    {'type': 'choice', 'question': 'How good is your vision?', 'qkey': 'user_eye_quality', 'options': ['', 'Excellent', 'Good', 'Fair', 'Poor', 'Bad', 'Hard']},
    {'type': 'choice', 'question': 'What is your relationship with your conversation partner?', 'qkey': 'user_familiarity', 'options': ['', 'Stranger', 'Colleague / Classmate', 'Acquaintance', 'Friends', 'Family']},
    {'type': 'choice', 'question': 'Did you play or take part in a Survival Game or related task?', 'qkey': 'user_survival_game', 'options': ['', 'Yes', 'No']},
    {'type': 'input', 'question': 'What is your native language?', 'qkey': 'user_language'}
]
%>
  <hr>
  % for q in questions:
    % if q["type"] == "choice":
      <div class="input-group questionnaire-selection">
        <span class="input-group-addon questionnaire-question" id="sizing-addon2">{{q['question']}}</span>

        <select name="{{q['qkey']}}" class="form-control" required>
          % for option in q['options']:
            % if option == "":
              <option value="">Please choose answer</option>

            % else:
              <option value="{{option}}">{{option}}</option>
            % end
          % end
        </select>
      </div>
    % end
    % if q["type"] == "input":
      <div class="input-group questionnaire-selection">
        <span class="input-group-addon questionnaire-question" id="sizing-addon2">{{q['question']}}</span>
        % if "default" in q:
          <input name="{{q['qkey']}}" type="text" class="form-control" value="{{q['default']}}" required ></input>
        % else:
          <input name="{{q['qkey']}}" type="text" class="form-control" required placeholder="e.g."></input>
        % end
      </div>
    % end

    % if q["type"] == "sep":
      <hr>
    % end
    % # add other question types in a similar way

  % end

  <hr>

  <div class="input-group">
    <input type="hidden" id="screen_size" name="screen_size" placeholder="screen_size" />
    <input type="hidden" id="browser_agent" name="browser_agent" placeholder="browser_agent" />
  </div>

  <div class="col-lg-2">
    <button type="submit" class="btn btn-success">continue</button>

    % if dev:
      <button type="submit" class="btn btn-success" formnovalidate>skip (for dev)</button>
    % end

  </div>
</form>

