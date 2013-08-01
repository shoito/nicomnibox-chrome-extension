typeRegex = /^:(video|live|illust|manga|book|channel|blomaga)\ /i;

suggestByNico = (text, callback) ->
  return if text is ""

  queryInfo = resolveText(text)
  console.log queryInfo
  
  url = "http://sug.search.nicovideo.jp/suggestion/complete"
  req = new XMLHttpRequest()
  req.open "POST", url
  
  req.onreadystatechange = =>
  	if req.readyState is 4 and req.status is 200
	  	candidates = JSON.parse(req.responseText).candidates.map (candidate, i) ->
	  		{
	  			content: if queryInfo.type? then ":" + queryInfo.type + " " + candidate else candidate
	  			description: candidate + "<dim> - 新検索β 検索</dim>"
	  		}
	  	callback candidates

  req.send queryInfo.text
  req

resolveText = (text) ->
  typeResult = typeRegex.exec text
  if typeResult?
  	{text: text.replace(typeResult[0], ""), type: typeResult[1]}
  else
  	{text: text, type: null}

getUrl = (text = "") ->
  queryInfo = resolveText(text)
  baseUrl = "http://search.nicovideo.jp"
  urlSuffix = "/search/" + encodeURIComponent(queryInfo.text.trim()) + "?omnibox"
  if queryInfo.type?
  	baseUrl + "/" + queryInfo.type + urlSuffix
  else
  	baseUrl + urlSuffix

chrome.omnibox.onInputChanged.addListener (text, suggest) ->
  suggestByNico text, suggest

chrome.omnibox.onInputEntered.addListener (text) ->
  url = getUrl text
  chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->
    chrome.tabs.update tabs[0].id, {url: url}