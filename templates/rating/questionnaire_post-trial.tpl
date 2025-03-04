<!-- this template defines a radio button form.
When creating custom forms copy this basic structure.
Don't change the form attributes "action" and "method"-->

<style>

.slider {
  width: 100% !important;
}

</style>


<div class="col-12" id="ratingform" >
  % route = f"save_rating?stimuli_idx={stimuli_idx}" if not train else "training/" + str(stimuli_idx + 1)
  <form id="form1" action="/{{route}}" method="post">
    
<%
adjective_pairs = [
    ["cold", "warm"],
    ["impersonal", "personal"],
    ["colorless", "colorful"],
    ["passive", "active"],
    ["closed", "open"],
    ["ugly", "beautiful"],
    ["small", "large"],
    ["insensitive", "sensitive"],
    ["unsociable", "sociable"],

]

questions = [
  "I enjoyed interacting with this interface.",
  "The system was well suited to the task.",
  "It felt natural to interact through the system.",
  "My partner is happy with the result of the exercise.",
  "I am happy with the result of the exercise.",
  "My partner was satisfied with the final layout.",
  "I was satisfied with the final layout.",
  "My partner and I often compromised.",
  "I knew when I could speak.",
  "My partner had appropriate body language.",
  "There were awkward pauses.",
  "I enjoyed working with my partner.",
  "I think the other individual often felt alone.",
  "I often felt as if I was all alone.",
  "My opinions were clear to the other.",
  "The opinions of the other were clear.",
  "My thoughts were clear to my partner.",
  "The other individual's thoughts were clear to me.",
  "The other understood what I meant.",
  "I understood what the other meant.",
  "My partner often spoke for longer than necessary.",
  "I often understood what my partner was referring to.",
  "My partner worked with me to complete the task.",
  "I worked with the other individual to complete the task.",
  "I perceive that I am in the presence of another person in the room with me.",
  "I feel that the person is watching me and is aware of my presence.",
  "I was interrupted often by my partner.",
  "I interrupted my partner often.",
  "It was difficult to interrupt my partner.",
  "It was difficult to get my partner's attention.",
  "My partner was paying a lot of attention to me.",
  "I could tell what my partner was paying attention to.",
  "I am confident I understood the emotions expressed by my partner."

]
%>
     <table class="table table-sm" id="questions1">
      <thead>
        <tr>
          <th scope="col"></th>
          <th scope="col"></th>
          <th scope="col">Strongly applicable</th>
          <th scope="col" style="text-align:center">Neither applicable</th>
          <th scope="col">Strongly applicable</th>
          <th scope="col"></th>
        </tr>
      </thead>
      <tbody>
          <tr><th colspan="5">Please rate to which degree you feel each adjective describes the communication medium!</th></tr>
            % for adj1, adj2 in adjective_pairs:
            <tr>
              <td style="width:5%"></td>

              <td style="width:15%" >{{adj1}}</td>

              <td style="width:8em; text-align:right">1</td>
              <td style="width:50%">
                <input
                    type="range"
                    class="form-range slider"
                    name="range_{{adj1}}_{{adj2}}"
                    id="range_{{adj1}}_{{adj2}}"
                    min="1"
                    max="7"
                    value="4"
                    oninput="slider_change(this)"
                    onchange="slider_change(this)"
                    list="steplist"
                />
              <datalist id="steplist">
                  <option>1</option>
                  <option>2</option>
                  <option>3</option>
                  <option>4</option>
                  <option>5</option>
                  <option>6</option>
                  <option>7</option>
              </datalist>
              </td>
              <td style="width:8em; padding-right:2em">7</th>
              <td style="width:15%" >{{adj2}} <br> &nbsp</td>

              <td style="width:15%" ><input type="number" id="label_range_{{adj1}}_{{adj2}}" style="width:3em" onchange="update_slider(this, 'range_{{adj1}}_{{adj2}}')" required></td>
            </tr>
            % end
      </tbody>
    </table>
    <div class="alert alert-danger" id="hint" role="alert" style="display:none">
      Please move each slider.
    </div>

    <button type="button" class="btn btn-info" id="next_button" onclick="next_questions_part()">next</button>


     <table class="table table-sm" id="questions2" style="display:none">
      <thead>
        <tr><th colspan="8">Please rate the following statements on the following scale:<br>1 - Strongly Disagree, 2 - Disagree, 3 - Somewhat Disagree, 4 - Neither Agree nor Disagree, 5 - Somewhat Agree, 6 - Agree, 7- Strongly Agree</th></tr>
      </thead>
      <tbody>
          % for question in questions:
          <tr><th colspan="5">{{question}}</th></tr>
            <%
            import re
            question_key = re.sub("[^0-9a-zA-Z]+", "", question).lower()

            %>
            <tr>
              <td style="width:5%"></td>

              <td style="width:15%" >Strongly Disagree</td>

              <td style="width:8em">1</td>
              <td style="width:50%">
                <input
                    type="range"
                    class="form-range slider"
                    name="range_{{question_key}}"
                    id="range_{{question_key}}"
                    min="1"
                    max="7"
                    value="4"
                    oninput="slider_change(this)"
                    onchange="slider_change(this)"
                    list="steplist"
                />
              <datalist id="steplist">
                  <option>1</option>
                  <option>2</option>
                  <option>3</option>
                  <option>4</option>
                  <option>5</option>
                  <option>6</option>
                  <option>7</option>
              </datalist>
              </td>
              <td style="width:8em; padding-right:2em">7</th>
              <td style="width:15%" >Strongly Agree<br> &nbsp</td>

              <td style="width:15%" ><input type="number" id="label_range_{{question_key}}" style="width:3em" onchange="update_slider(this, 'range_{{question_key}}')" required></td>
            </tr>
            % end
      </tbody>
    </table>




    <!--This input field contains the mouse tracking data and needs to be declared inside the submit form -->
    <input type="hidden" id="mouse_track" name="mouse_track" value=""/>

    % include('templates/rating/common.tpl', stimuli_file=stimuli_file)

    <!--<div class="row"> -->
    <button type="submit" id="submitButton" class="btn-lg btn-success btn-block" style="margin-top: 2em;display:none" onclick="log_position()">Submit and continue</button>
    <!-- </div> -->
  </form>
</div>

<!-- this script enables the submit button after one option was checked -->
<script>
$(document).ready(function(){
    $(".funkyradio-success").click(function(){
        $("#submitButton").removeAttr("disabled");
    });
});


var slidersChanged = {};
// initialize sliders
for (const slider of document.querySelectorAll('input.slider')) {
    slidersChanged[slider.getAttribute("name")] = 0;
}
function update_slider(input, range_id) {
    var slider = document.getElementById(range_id);
    slider.value = input.value
}

function slider_change(slider) {
    console.log("change");
    const label = document.getElementById("label_" + slider.getAttribute("name"));
    //label.textContent = slider.value;
    label.value = slider.value;

    slidersChanged[slider.getAttribute("name")] = 1;
    var check = Object.values(slidersChanged).every(e => e > 0);

    // if (check) {
    //     document.getElementById("submitButton").disabled = false;
    // }
}


function next_questions_part() {
    console.log("here");
    // check:
    inputs = document.getElementById("questions1").querySelectorAll("input[type='number']");
    check = true;
    inputs.forEach(e => check = check & (e.value != ""));
    if (check) {
      document.getElementById("hint").style.display="none";
      document.getElementById("questions1").style.display = "none";
      document.getElementById("next_button").style.display = "none";
      document.getElementById("questions2").style.display = "block";
      document.getElementById("submitButton").style.display = "block";
    }
    else {
      document.getElementById("hint").style.display="block";
    }

}

</script>
