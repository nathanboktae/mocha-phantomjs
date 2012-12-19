describe '<iframe>', ->

  it 'allow us to remove an iframe that is not finished downloading', ->
    iframe = document.createElement "iframe"
    iframe.src = "blank.html"
    document.body.appendChild iframe
    iframe.parentNode.removeChild iframe

  it 'allow us to destroy an iframe reference that is not finished downloading', ->
    iframe = document.createElement "iframe"
    iframe.src = "blank.html"
    iframe = null

  it 'allow us to change the src of an iframe that is not finished downloading', ->
    iframe = document.createElement "iframe"
    iframe.src = "blank.html"
    iframe.src = "about:blank"
