# API

All events for fetchu, and their properties are listed here.

# Events

<hr />

**get**

```lua
fetchu.get(requestUrl: string, {headers: Dictionary<any>?, nocache: boolean?})
```

Send an HTTP GET request

<hr />

**post**

```lua
fetchu.post(requestUrl: string, {content_type: Enum.HttpContentType?, headers: Dictionary<any>?, body: Dictionary<any>, compress: boolean?,})
```

Send an HTTP POST request

<hr />

**json**

```lua
fetchu.json(input: table)
```

Transforms Luau table input into a JSON string.

<hr />

**tablefy**

```lua
fetchu.tablefy(input: JSON)
```

Transforms JSON string into a Luau table.

<hr />

**put**

```lua
fetchu.put(requestUrl: string, {headers: Dictionary<any>?,body: Dictionary<any>?,})
```

Send an HTTP PUT request

<hr />

**delete**

```lua
fetchu.delete(requestUrl: string, {headers: Dictionary<any>?,body: Dictionary<any>?,})
```

Send an HTTP DELETE request

<hr />

**customRequest**

```lua
fetchu.customRequest(requestUrl: string, {method: string, headers: Dictionary<any>?,body: Dictionary<any>?,})
```

Sends an HTTP request using a custom method such as CONNECT, PATCH, etc listed on the **FetchOptions** paramater.

<hr />
