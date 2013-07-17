BindingsClass =

  model: 'model'

  bindings: {}


BindingsInstance =

  getModel: ->
    @[@constructor.model]

  setModel: (model) ->
    @[@constructor.model] = model

  walkBindings: (fn) ->
    for selector, field of @constructor.bindings
      fn selector, field

  applyBindings: ->
    @walkBindings (selector, field) =>
      @_bindModelToEl @getModel(), field, selector
      @_bindElToModel @getModel(), field, selector

  _forceModelBindings: (model) ->
    @walkBindings (selector, field) =>
      @$(selector).val model[field]

  changeBindingSource: (model) ->
    @getModel().unbind 'change'
    @walkBindings (selector) => @el.off 'change', selector
    @setModel model
    @_forceModelBindings model
    do @applyBindings

  _bindModelToEl: (model, field, selector) ->
    @el.on 'change', selector, ->
      model[field] = $(this).val()

  _bindElToModel: (model, field, selector) ->
    model.bind 'change', => @$(selector).val model[field]

Spine.Controller.extend BindingsClass
Spine.Controller.include BindingsInstance