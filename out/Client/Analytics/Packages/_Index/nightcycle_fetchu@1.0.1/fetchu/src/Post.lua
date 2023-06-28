local HttpService = game:GetService("HttpService")

export type FetchOptions = {
    content_type: Enum.HttpContentType?,
    headers: any?,
    body: any,
    compress: boolean?,
    tablefy: boolean?
}

return function (url: string, options: FetchOptions)
    local success,result = pcall(function()
        local body = HttpService:JSONEncode(options.body)
        return HttpService:PostAsync(url, body, options.content_type or Enum.HttpContentType.ApplicationJson, options.compress or false, options.headers)		
    end)

    if not success then
        return error(result)
    end

    if (options and options.tablefy) then
        return HttpService:JSONDecode(result)
    end

    return result
end