local shell = require( "shell" )
local fs = require( "filesystem" )

ABSPATH = "/home/htmlFiles/"

function findLast( haystack, needle )
    local i = string.match( haystack, ".*" .. needle .. "()" )
    if i == nil then
      return nil
    else
      return i - 1
    end
end

function getFileName( tempString )
  local lastSlashIndex = findLast( tempString, "/" )
  return string.sub( tempString, lastSlashIndex + 1 )
end

function createDirectory( requestedPath )

  if not fs.exists( ABSPATH ) then
    shell.execute( "mkdir htmlFiles" )
  end

  if not fs.exists( requestedPath ) then
    shell.execute( "mkdir " .. requestedPath )
  end
end

function getSaveFileName( requestedFileName )

  while fs.exists( ABSPATH .. requestedFileName ) do
    requestedFileName = requestedFileName .. "-extend"
  end

  return requestedFileName
end

function getHtml( link )

  local fileName = getFileName( link )
  local saveFileName = getSaveFileName( fileName )

  shell.execute( "wget " .. link .. " " .. ABSPATH .. saveFileName )
  return ABSPATH .. saveFileName
end

function extractURL( inputString )

  local _, stop = string.find( inputString, "(.+href=\")" )
  local temp = string.sub( inputString, stop + 1, string.len( inputString ) )
  local start, _ = string.find( temp, "\"" )

  return string.sub( temp, 1, start - 1 )
end

function extractHtmlFile( file, isDir )

  if isDir then
    local saveDir = "/Home/" .. getFileName( file )
    createDirectory( saveDir )
  else
    local saveDir = "/home/"
  end

  if fs.exists( file ) then
    htmlFile = io.open( file, "r" )
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

      if string.find( line, "directory" ) and not string.find( line, "Go to parent directory" ) then
        isDirectory = true
      end

      if string.find( line, "<a href=\"" ) and not string.find( line, "commit" ) and not string.find( line, "Go to parent directory" ) then

        if isDirectory then
          local tempFile = getHtml( "https://github.com" .. extractURL( line ) )
          extractHtmlFile( tempFile, true )
          isDirectory = false
        else
          print( saveDir )
        end
      end
    end
  end
end

local myrepo = "https://github.com/Acconitum/minecraft.git"
local myfile = getHtml( myrepo )
extractHtmlFile( myfile )


shell.execute( "rm -rf "  .. ABSPATH )
