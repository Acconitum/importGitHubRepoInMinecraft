local myrepo = "https://github.com/Acconitum/minecraft.git"
local shell = require( "shell" )
local fs = require( "filesystem" )


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

function getSavePath( link )

  local placeHolder = "master"

  if string.find( link, placeHolder ) then

    _, stop = string.find( link, placeHolder )
    local savePath = string.sub( link, stop + 2 )
    local start = findLast( savePath, "/" )
    local temp = string.sub( savePath, 1, start - 1)
    createDirectory( ABSPATH .. REPONAME .. "/" .. temp )
    return savePath
  end
end

function getSaveFileName( requestedFileName )

  while fs.exists( ABSPATH .. requestedFileName ) do
    requestedFileName = requestedFileName .. "-extend"
  end

  return requestedFileName
end

function getHtml( link )

  if string.find( link, "https" ) then
    shell.execute( "wget " .. link .. " " .. ABSPATH .. REPONAME .. "/" .. getFileName( link ) .. ".html" )
    return ABSPATH .. REPONAME .. "/" .. getFileName( link )
  else
    local prefix = "https://raw.githubusercontent.com"
    shell.execute( "wget " .. prefix .. link .. " " .. ABSPATH .. REPONAME .. "/" ..  getSavePath( link ) )
  end
  return link
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

function extractHtmlFile( file )

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
          extractHtmlFile( tempFile )
          isDirectory = false
        else
          getHtml( extractURL( line ) )
        end
      end
    end
  end
  htmlFile:close()
end

local temp = getFileName( myrepo )
local gitExtension, _ = string.find( temp, ".git" )
REPONAME = string.sub( temp, 1, gitExtension - 1 )
ABSPATH = "/home/"

--local i = 1
--while fs.exists( ABSPATH .. REPONAME .. savePath ) do
  --savePath = savePath .. i
  --i = i + 1
--end

--TODO handling if repository already exists
createDirectory( ABSPATH .. REPONAME )

local myfile = getHtml( myrepo )
extractHtmlFile( myfile )
