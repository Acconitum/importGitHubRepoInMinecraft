local shell = require( "shell" )
local fs = require( "filesystem" )

function findLast( haystack, needle )
    local i = haystack:match( ".*" .. needle .. "()" )
    if i == nil then
      return nil
    else
      return i - 1
    end
end

function getHtml( link )

  local lastSlashIndex = findLast( link, "/" )
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

function extractHtmlFile( file )

  if fs.exists( file ) then
    local htmlFile = io.open( file, "r" )
  else
    print( file .. " not found")
    return
  end

  local pattern = "<table class=\"files"
  local endPattern = "</table>"
  local patternFound = false
  local isDirectory = false
  local index = 1

  for line in htmlFile:lines() do

    if string.find( line, pattern ) then
      patternFound = true
    end

    if string.find( line, endPattern ) then
      patternFound = false
    end

    if patternFound then

      if string.find( line, "directory" ) then
        isDirectory = true
      end

      if string.find( line, "<a href=\"" ) and not string.find( line, "commit" ) then
        print( extractURL( line) )
      end


    end
  end

end

local myrepo = "https://githun.com/Acconitum/minecraft.git"
local myfile = getHtml( repo )
extractHtmlFile( myfile )
