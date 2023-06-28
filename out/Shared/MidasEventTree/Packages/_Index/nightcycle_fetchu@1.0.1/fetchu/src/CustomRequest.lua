local HttpService = game:GetService("HttpService")

export type FetchOptions = {
    headers: any?,
    body: any?,
    tablefy: boolean?
}

return function (url: string, options: FetchOptions & {method: string?})
    local success,result = pcall(function()
        local requestOptions = {
            Url = url,
            Method = (options and options.method) or nil,
            Body = (options and options.body and HttpService:JSONEncode(options.body)) or nil,
            Headers = (options and options.headers) or nil,
        }
        return HttpService:RequestAsync(requestOptions)
    end)

    if not success then
        return error(result)
    end

    if (options and options.tablefy) then
        return HttpService:JSONDecode(result)
    end

    return result
end