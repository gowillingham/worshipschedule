var _glow_color = "#feff8f"

$(document).ready(function(){
  
  // show 'working ' message during ajax actions ..
  $.loading({onAjax: true, text: 'Please wait ..'})
  
  $('.head_coach_checkbox, .team_dropdown_list').parent('form').bind('ajax:success', function(){
    $.loading(false)
    $.loading(true, {text: 'Ok, registration saved .. ', max: 3000})
  })
  
  $('.confirm_by_email_trigger').parent('form').bind('ajax:success', function(){
    $.loading(false)
    $.loading(true, {text: 'Your message has been sent. ', max: 3000})
  })
  
  // bind registration confirm button ..
  $(".confirm_by_email_trigger").click(function(){
    var id = []
    var id_list
    var form = $(this).parent("form")
    
    if ($(".registration_id:checked").length == 0) {
      $.loading(false)
      $.loading(true, {text: 'No registrations selected! ', max: 3000})
      return false
    }
    
    // get registration_id's from the grid and load them into the form ..
    $(".registration_id:checked").each(function(){
      id.push($(this).val())
    })
    id_list = id.join()    
    $("input[name=id_list]", form).attr("value", id_list)

    form.submit()
    return false
  })
  
  // bind master checkbox ..
  $(".master_checkbox input").click(function(){
    $(".registration_id").attr("checked", $(this).attr("checked"))
  })
  
  // arm the filter dropdowns ..
  $(".controls form select, .controls form input").change(function(){
    $(this).parent("form").submit()
  })
  
  // commit and highlight grid rows that are updating ..
  $(".head_coach_checkbox, .team_dropdown_list").change(function(){
    $(this).parent("form").submit()
    $(this).parents("tr").glow(_glow_color, 1000, 100) 
  })
  
  $(".sort_grid").tablesorter()
  
  // bind expander to notes column ..
  $(".notes").expander({
    slicePoint: 10,
    widow: 2,
    expandText: 'more',
    expandEffect: 'show',
    userCollapseText: 'hide'
  })
})