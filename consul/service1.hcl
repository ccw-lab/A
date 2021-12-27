{
    "service": {
      "id": "web-1",
      "name": "web",
      "tags": [
        "primary"
      ],
      "address": "121.189.57.82",
      "meta": {
        "meta": "for my service"
      },
      "port": 80,
      "enable_tag_override": false,
      "checks": {
        "name": "HTTP 1",
        "http": "http://localhost:4200/",
        "method": "GET",
        "interval": "10s",
        "timeout": "1s"
      },
      "token": "233b604b-b92e-48c8-a253-5f11514e4b50",
    }
  }