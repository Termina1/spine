describe('Bindings', function() {

  TestController = Spine.Controller.sub({
    modelVar: 'tmodel',
    elements: { '.testValues': 'input' },
    bindings: {
      '.testValues': 'value'
    }
  });

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

  it("changes source model of bindings", function() {
    md = new TestModel({ value: 'another test' });

    controller.changeBindingSource(md);
    expect(controller.input.val()).toEqual('another test');

    md.value = 'new test';
    md.save();
    expect(controller.input.val()).toEqual('new test');
    expect(model.value).toEqual('init');

    controller.input.val('new test 2');
    controller.input.trigger('change');
    expect(md.value).toEqual('new test 2');
    expect(model.value).toEqual('init');

    model.value = 'init2';
    model.save();
    expect(controller.input.val()).not.toEqual('init2');
  });

});