local shell = require( "shell" )
local fs = require( "filesystem" )
local tablePattern = "<table class=\"files"

function getHtml( link )

  local lastSlashIndex = link.lastIndexOf( "/" )
  local fileName = string.sub( link, lastSlashIndex )

  if not fs.exists( "htmlFiles" ) then
    shell.execute( "mkdir htmlFiles" )
  end

  if fs.exists( "htmlFiles/" .. fileName ) then
    fileName = fileName .. ".extended"
  end

  shell.execute( "wget" .. link .. " htmlFiles/" .. fileName )
  return "htmlFiles/" .. fileName
end

function extractURL( inputString )

  local _, stop = string.find( inputString, "(.+href=\")" )
  local temp = string.sub( inputString, stop, string.len( inputString ) )
  local start, _ = string.find( temp, "\"" )
  
  return string.sub( temp, 1, start )
end
