local shell = require( "shell" )
local fs = require( "filesystem" )
local tablePattern = "<table class=\"files"

function getHtml( link )
  local offset = 10
  shell.execute( "mkdir -q htmlFiles" )
  if fs.exists( "htmlFiles/" .. string.sub( link, string.len( link ) - offset ) ) then
    offset = offset + 1
  end
  shell.execute( "wget" .. link .. " htmlFiles/" .. string.sub( link, string.len( link ) - offset ) )
  return "htmlFiles/" .. string.sub( link, string.len( link ) - offset )
end

function extractURL( inputString )
  local _, stop = string.find( inputString, "(.+href=\")" )
  local temp = string.sub( inputString, stop, string.len( inputString ) )
  local start, _ = string.find( temp, "\"" )
  return string.sub( temp, 1, start )
end
