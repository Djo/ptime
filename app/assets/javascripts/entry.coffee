# Handles time entry creation and modification including specific time/date
# picker logic

$ ->
  window.entry = entry = $('#entry-ui-datepicker')
  return unless entry.length

  # Add chosen
  $('.chzn-select').chosen()

  # Add time input method radio button logic
  entry.toggleTimeInputMethod = ->
    entry.toggleDisable($('#entry_start'))
    entry.toggleDisable($('#entry_end'))
    entry.toggleDisable($('#entry_duration_hours'))

  # Toggle disabled state of the given field
  entry.toggleDisable = (field) ->
    if field.attr('disabled')
      field.removeAttr('disabled')
    else
      field.attr('disabled', true)

  # Save the chosen method in a cookie
  entry.saveInputTimeMethod = (field) ->
    $.cookie('savedMethod' : field.val())

  # Initialize by checking if cookie for entry method is present
  # otherwise just disable the duration field by default
  savedMethod = $.cookie('savedMethod')
  if savedMethod == 'duration'
    $('#entry_start').attr('disabled', true)
    $('#entry_end').attr('disabled', true)
    $('input[name=time_capture_method]').attr('checked', true)
  else
    entry.toggleDisable($('#entry_duration_hours'))


  # If the duration field contains values and start/end don't, activate it
  if $('#entry_duration_hours').val() isnt '' and
    $('input[name=time_capture_method]:checked').val() is 'start_end' and
    $('#entry_start').val() is '' and
    $('#entry_end').val() is ''
      entry.toggleTimeInputMethod()
      $('#time_capture_method_duration').attr('checked', true)

  # Toggle between date or time entry method by either disabling
  #  * the duration field
  #  * the start -and end time picker fields
  $('input[name=time_capture_method]').click ->
    entry.saveInputTimeMethod($(this))
    entry.toggleTimeInputMethod()

  # Reload entry form for chosen date
  $('#entry-ui-datepicker').datepicker({
    onSelect: (dateText, inst) ->
      date = new Date(dateText)
      day = $.datepicker.formatDate("dd-mm-yy", date)
      window.location.href = '/entries/new/' + '?day=' + day;
  })

  # Change date on entry datepicker. It will be set by new and edit actions
  $('#entry-ui-datepicker').datepicker('setDate', new Date($('input#entry_day_input').val()))

  # Calculate entry duration from start:end
  $('#entry_end').change ->
    start_time = $('#entry_start').val()
    end_time = $('#entry_end').val()
    if start_time
      start_date = new Date('1/1/70 ' + start_time)
    end_date = new Date('1/1/70 ' + end_time)
    if end_date > start_date
      diff = new Date()
      diff.setTime(end_date - start_date)
      $('#entry_duration_hours').val(diff.getUTCHours()+':'+ $.format('%02d', [diff.getUTCMinutes()]))
    else
      $('#entry_duration_hours').val('')

  # Discard entry start:end if duration is edited manually
  $('#entry_duration_hours').change ->
    $('#entry_start').val('')
    $('#entry_end').val('')

  # Fetch associated tasks for a given project in entry form
  entry.fetchAssociatedTasks = ->
    $('#entry_task_id').find('option').remove()
    project_id = $('select#entry_project_id :selected').val()
    tasks_from_projects = $.parseJSON($('#tasks_collection_storage').val())
    for i, item of tasks_from_projects[project_id]
      $('#entry_task_id').append(
        $('<option></option>').val(item.id).html(item.name))

  # Update project's tasks, normal version
  $('#entry_project_id').change ->
    entry.fetchAssociatedTasks()

  # Update project's tasks, chosen version
  $('#entry_project_id.chzn-select').chosen().change ->
    entry.fetchAssociatedTasks()
    $('#entry_task_id.chzn-select').trigger('liszt:updated')

  # Focus next field on input after choosing a task
  $('#entry_task_id').click ->
    $('#entry_description').focus()
