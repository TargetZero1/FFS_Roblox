--!strict

--[[
    Lightweight package made for easier request handling.
]]

local HttpService = game:GetService("HttpService")

local fetchu = {}

local Get = require(script.Get)
local Post = require(script.Post)
local CustomRequest = require(script.CustomRequest)


fetchu.get = function (url: string, options: Get.FetchOptions?)
    if not url then
        return error("No request URL has been passed.")
    end
    return Get(url, options)
end

fetchu.post = function (url: string, options: Post.FetchOptions)
    if not url then
        return error("No request URL has been passed.")
    end
    return Post(url, options)
end

fetchu.put = function (url: string, options: CustomRequest.FetchOptions)
    if not url then
        return error("No request URL has been passed.")
    end
    return CustomRequest(url, {method = "PUT", table.unpack(options or {})})
end

fetchu.delete = function (url: string, options: CustomRequest.FetchOptions)
    if not url then
        return error("No request URL has been passed.")
    end
    return CustomRequest(url, {method = "DELETE", table.unpack(options or {})})
end

fetchu.customRequest = function (url: string, method: string, options: CustomRequest.FetchOptions)
    if not url then
        return error("No request URL has been passed.")
    end
    return CustomRequest(url, {method = method, table.unpack(options or {})})
end

fetchu.json = function(input: table)
    HttpService:JSONEncode(input)
end

fetchu.tablefy = function(json: string)
    HttpService:JSONDecode(json)
end

fetchu.generateGUID = function(curlyBraces: boolean?)
    return HttpService:GenerateGUID(curlyBraces)
end


return fetchu