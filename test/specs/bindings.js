describe('Bindings', function() {

  TestController = Spine.Controller.sub({});
  TestController.model = 'tmodel';
  TestController.elements = { '.testValues': 'input' }
  TestController.bindings = {
    '.testValues': 'value'
  };

  TestModel = Spine.Model.sub({});
  TestModel.configure('TestModel', 'value');

  controller = {};
  model = {};

  beforeEach(function() {
    model = new TestModel({ value: 'init' });
    controller = new TestController({ tmodel: model });
    controller.applyBindings()
    controller.el.append($('<input class="testValues" value="init" type="hidden"/>'))
    controller.refreshElements();
    controller.el.appendTo($('body'))
  });

  afterEach(function() {
    controller.release();
    TestModel.deleteAll();
  });

  it("change element when model has changed", function() {
    model.value = 'changed';
    model.save();
    expect(controller.input.val()).toEqual(model.value);
  });

  it("change model when element has changed", function() {
    controller.input.val('new test');
    controller.input.trigger('change');
    expect(model.value).toEqual('new test');
  });

});