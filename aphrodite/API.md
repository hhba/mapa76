Mapa76: API
===========

Keep in mind that this documentation is based on `/api/v2` which is a termporal version for testing purposes.
Since documets are associated to users, you will need to authenticate into the app in order to user the API. We are using HTTP Token Authentication to do this job. More info [here](http://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token.html). We use the `Authorization` header attribute to send the authentication token as:

    curl http://localhost:3000/api/products -H 'Authorization: Token token="YOURTOKENHERE"'

or, in a RESTful client just add the header `Authorization` with the value `Token token="YOURTOKENHERE"`.

### GET api/v2/documents

```json
[
  {
    "id": "52704be53ea2af7657000009",
    "title": "scioli.txt",
    "created_at": "2013-10-29T23:59:33Z",
    "percentage": 100,
    "counters": {
      "people": 8,
      "organizations": 12,
      "places": 10,
      "dates": 2
    }
  },{
    "id": "52725a0d3ea2af765700000c",
    "title": "economy.txt",
    "created_at": "2013-10-31T13:24:29Z",
    "percentage": 100,
    "counters": {
      "people": 8,
      "organizations": 12,
      "places": 10,
      "dates": 2
    }
  }
]
```

### GET api/v2/documents/52704be53ea2af7657000009

```json
{
  "id":"52704be53ea2af7657000009",
  "title":"scioli.txt",
  "description":null,
  "published_at":null,
  "created_at":"2013-10-29T23:59:33Z",
  "context_cache":{
    "id":"52704be53ea2af7657000009",
    "title":"scioli.txt",
    "registers":[],
    "people":[{
      "id":"524c782f3ea2af1c09000001",
      "name":"Cristina Kirchner",
      "mentions":2
    },{
      "id":"526fccf63ea2afae27000001",
      "name":"Daniel Scioli",
      "mentions":2
    }],
    "dates":[{
      "text":"domingo",
      "mentions":4
    }],
    "organizations":[{
      "text":"PASO",
      "mentions":4
    },{
      "text":"Frente Renovador",
      "mentions":1
    }],
    "places":[{
      "text":"Buenos Aires",
      "mentions":2
    }],
    "has_registers":false,
    "has_people":true,
    "has_dates":true,
    "has_organizations":true,
    "has_places":true
  },
  "status":"coreference_resolution_task-end",
  "percentage":100.0
}
```

### GET api/v2/documents/status

Remeber, completed documents are not being listed. And **failed** are marked with a percentage of **-1**.

```json
[{
  "id":"5276587b07c6176463000006","percentage":50.0
},{
  "id":"5276587b07c617646300000c","percentage":50.0
}]
```

### DELETE api/v2/documents/52704be53ea2af7657000009

### DELETE api/v2/documents/destroy_multiple

This request must include the header attribute `X-Document-Ids` with the ids separated by `,`.

### POST api/v2/documents/52704be53ea2af7657000009/flag

### GET api/v2/documents/52704be53ea2af7657000009/people

### GET api/v2/people/524c782f3ea2af1c09000001

```json
{
  "id":"524c782f3ea2af1c09000001",
  "name":"Cristina Kirchner",
  "mentioned_in":[{
    "id":"52704be53ea2af7657000009",
    "title":"scioli.txt",
    "mentions":2
  }]
}
````

### GET api/v2/people
This request must include the header attribute `X-Document-Ids` with the ids separated by `,`. For example: `52704be53ea2af7657000009,52725a0d3ea2af765700000c`

```json
[
  {
    "id": "524c782f3ea2af1c09000001",
    "name": "Cristina Kirchner",
    "mentions":
    {
        "526fc92e3ea2af7657000006": 2,
        "52704be53ea2af7657000009": 2
    }
  },
  {
    "id": "526fccf63ea2afae27000001",
    "name": "Daniel Scioli",
    "mentions":
    {
        "526fc92e3ea2af7657000006": 2,
        "52704be53ea2af7657000009": 2
    }
  }
]
```
