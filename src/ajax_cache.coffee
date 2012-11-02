class Cached
  constructor: (@keyStr, @data) ->

  getData: -> @data

  exists: -> @data?

Spine.AjaxCache =

  #MurMurHash3 implementation

  hashf: (key, seed) ->
    remainder = key.length & 3 # key.length % 4
    bytes = key.length - remainder
    h1 = seed
    c1 = 0xcc9e2d51
    c2 = 0x1b873593
    i = 0
    while i < bytes
      k1 = (key.charCodeAt(i) & 0xff) | ((key.charCodeAt(++i) & 0xff) << 8) | ((key.charCodeAt(++i) & 0xff) << 16) | ((key.charCodeAt(++i) & 0xff) << 24)
      ++i
      k1 = (((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16)) & 0xffffffff
      k1 = (k1 << 15) | (k1 >>> 17)
      k1 = (((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16)) & 0xffffffff
      h1 ^= k1
      h1 = (h1 << 13) | (h1 >>> 19)
      h1b = (((h1 & 0xffff) * 5) + ((((h1 >>> 16) * 5) & 0xffff) << 16)) & 0xffffffff
      h1 = (((h1b & 0xffff) + 0x6b64) + ((((h1b >>> 16) + 0xe654) & 0xffff) << 16))
    k1 = 0
    switch remainder
      when 3
        k1 ^= (key.charCodeAt(i + 2) & 0xff) << 16
      when 2
        k1 ^= (key.charCodeAt(i + 1) & 0xff) << 8
      when 1
        k1 ^= (key.charCodeAt(i) & 0xff)
        k1 = (((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16)) & 0xffffffff
        k1 = (k1 << 15) | (k1 >>> 17)
        k1 = (((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16)) & 0xffffffff
        h1 ^= k1
    h1 ^= key.length
    h1 ^= h1 >>> 16
    h1 = (((h1 & 0xffff) * 0x85ebca6b) + ((((h1 >>> 16) * 0x85ebca6b) & 0xffff) << 16)) & 0xffffffff
    h1 ^= h1 >>> 13
    h1 = (((h1 & 0xffff) * 0xc2b2ae35) + ((((h1 >>> 16) * 0xc2b2ae35) & 0xffff) << 16)) & 0xffffffff
    h1 ^= h1 >>> 16
    h1 >>> 0

  globalCache: {}

  createKeyString: (url, params) ->
    result = url
    for name, el of params
      result += "#{name}=#{el}" unless typeof el is 'function' or typeof el is 'object'
    result

  hashKey: (url, params) ->
    @hashf @createKeyString url, params

  store: (url, params, data) ->
    keyStr = @hashKey url, params
    @globalCache[keyStr] = new Cached data
    data

  get: (url, params) ->
    keyStr = @hashKey url, params
    @globalCache[keyStr] or new Cached

Cached::invalidate = ->
  delete AjaxCache.globalCache[@keyStr]


Spine.Model.AjaxCache =
  fetch: (params, options) ->
    url = Spine.Ajax.getUrl(@)
    cache = AjaxCache.get url, params
    if cache.exists() and not params.noCache
      @trigger 'ajaxSuccess', cache.getData()...
    else
      @one 'ajaxSuccess', (data, status, xhr) -> AjaxCache.store url, params, [data, status, xhr]  
      super params, options


