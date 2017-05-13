local myrepo = "https://github.com/Acconitum/minecraft.git"
local shell = require( "shell" )
local fs = require( "filesystem" )
ABSPATH = "/home/"


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

  if requestedPath == nil then
    return
  else
    if not fs.exists( requestedPath ) then
      shell.execute( "mkdir " .. requestedPath )
    end
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
  shell.execute( "wget " .. link .. " " .. saveDir .. saveFileName )

  return saveDir .. saveFileName
end

function extractURL( inputString )

  local _, stop = string.find( inputString, "(.+href=\")" )
  local temp = string.sub( inputString, stop + 1, string.len( inputString ) )
  local start, _ = string.find( temp, "\"" )
  local returnString = string.sub( temp, 1, start - 1 )
  local temp2 = returnString

  if string.find( temp2, "blob/" ) then
    start, stop = string.find( temp2, "blob/" )
    temp = string.sub( temp2, 1, start - 1  )
    temp2 = string.sub( temp2, stop + 1 , string.len( temp2 ) )
    return temp .. temp2
  else
    return returnString
  end

end

function extractHtmlFile( file, isDir )

  if isDir then
    saveDir = ABSPATH .. getFileName( file )
    createDirectory( saveDir )
  else
    saveDir = ABSPATH
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
  local prefix = "https://raw.githubusercontent.com"

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
          local tempFile = getHtml( "https://github.com" .. extractURL( line ), ABSPATH )
          saveDir = ABSPATH .. repoName .. getFileName( file )
          createDirectory( saveDir )
          extractHtmlFile( tempFile, isDirectory )
          isDirectory = false
        else
          getHtml( prefix .. extractURL( line ), saveDir )
        end
      end
    end
  end
  saveDir = ABSPATH .. repoName
  htmlFile:close()
end

local a = findLast( myrepo, "\." )
repoName = getFileName( string.sub( myrepo, a + 1 ) )
saveDir = ABSPATH .. repoName
createDirectory( ABSPATH )

local myfile = getHtml( myrepo, saveDir )
extractHtmlFile( myfile )
