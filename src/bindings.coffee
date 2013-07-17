BindingsClass =

  model: 'model'

  bindings: {}


BindingsInstance =

  getModel: ->
    @[@constructor.model]

  applyBindings: ->
    for selector, field of @constructor.bindings
      @_bindModelToEl @getModel(), field, selector
      @_bindElToModel @getModel(), field, selector

  _bindModelToEl: (model, field, selector) ->
    @el.delegate selector, 'change', ->
      model[field] = $(this).val()

  _bindElToModel: (model, field, selector) ->
    model.bind 'change', => @$(selector).val model[field]

Spine.Controller.extend BindingsClass
Spine.Controller.include BindingsInstance