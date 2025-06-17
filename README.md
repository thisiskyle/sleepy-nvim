# crapi - Client for REST APIs

### About

Simple client for testing REST APIs. 


### Usage

Request job layout:

```lua

{ 
    name = "", -- (optional) name of the job, will be used to name the response buffer
    request = { -- the data that build the actual curl command
        type = "", -- request type
        url = "", -- request url
        headers = { } -- list of header strings
        data = { -- list for the data portion of the request
            { encode = "" }, -- this will force '--data-urlencode' prefix before the string
            { raw = "" }, -- this will force '--data' prefix before the string
            { "" } -- this will use the request to decide which prefix to use 
        }
        additional_args = { }  -- list of additional curl arguments
    },
    command = "", -- (optional) a full curl command. This will override the request object
    after = function(data) end -- (optional) function runs after the response is loaded into the buffer
    test = function(data) end -- (optional) function for testing the response data
},

```

### Examples

GET request:

```lua

{ 
    name = "ditto", 
    request = { 
        type = "GET", 
        url = "https://pokeapi.co/api/v2/pokemon/ditto", 
        headers = { 
            "apikey:1234567890"
        }, 
        additional_args = {  
            "--ssl-no-revoke"
        },
    },
    command = nil, 
    after = function(data) 
        vim.cmd(":%!jq") -- formats the json
    end,
    test = function(data) 
        local assert = require("sleepy.assert")
        return {
            {
                name = "has limber ability",
                -- assumes data is json, follows a path and checks the key's value
                result = assert.json_path_value(data, { "abilities", 1, "ability", "name" }, "limber")
            },
            { 
                name = "name is ditto",
                -- searches the data for a string
                result = assert.data_contains(data, 'name.*ditto') 
            }
            {
                name = "has a name key",
                -- assumes data is json, follows a path and checks if a key exists
                result = assert.json_has_key(data, { "abilities", 1, "ability", "name" })
            }
        }
    end
},

```

### Using assert
