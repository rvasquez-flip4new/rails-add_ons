class window.WidgetReloader
  constructor: (container_id, widget_name, widget_action)->
    @container_id = container_id
    @widget_name = widget_name
    @widget_action = widget_action

  reload: ->
    console.log "Loading #{this.container_id}"
    $("##{this.container_id}").html("Loading...")
    $.ajax
      context: this
      type: 'POST'
      url: this.uri()
      headers:
        Accept: 'application/json'
        'X-CSRF-Token': this.csrf_token()
      success: (data) ->
        $("##{this.container_id}").html data
        return
      error: (jqXHR) ->
        msg = 'Sorry but there was an error: '
        $("##{this.container_id}").html msg + jqXHR.status + ' ' + jqXHR.statusText
        return

  csrf_token: ->
    $('meta[name=\'csrf-token\']').attr('content')

  encoded_widget_action_and_name: ->
    encodeURIComponent("#{this.widget_name}##{this.widget_action}")

  encoded_widget_action: ->
    encodeURIComponent(this.widget_action)

  base_path: ->
    $('meta[name=\'widget-base-path\']').attr('content')

  uri: ->
    "#{this.base_path()}/#{this.encoded_widget_action_and_name()}"

$(document).ready ->
  $('body').on 'click', "*[data-refresh]", ->
    button_id = $(this).attr('id')
    container_id = $(this).attr('data-refresh')
    widget_name = $("##{container_id}").attr('data-widget')
    widget_action = $("##{container_id}").attr('data-widgetaction')
    wr = new window.WidgetReloader(container_id, widget_name, widget_action)
    wr.reload()
    return