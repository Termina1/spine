describe("AjaxCache", function() {

  var params, url, data;

  beforeEach(function() {
    params = { text: 1, data: 'test', fn: function() {}, arr: [] }
    url = '/host?test';
    data = { test: 1, change: 'some test', arr: [1, 2] }

  })

  it("exits", function() {
    expect(Spine.AjaxCache).toBeDefined();
  })

  it("can hash", function() {
    var time = new Date().getMilliseconds();
    expect(Spine.AjaxCache.hashf('sometest really long test')).toEqual(3883037902);
    expect((new Date().getMilliseconds()) - time).toBeLessThan(10);
  })

  it("creates valid key string", function() {
    expect(Spine.AjaxCache.createKeyString(url, params)).toEqual("/host?testtext=1data=test")
  })

});