{
    "service": {
      "id": "web-2",
      "name": "web",
      "tags": [
        "secondary"
      ],
      "address": "223.130.195.95",
      "meta": {
        "meta": "for my service 2"
      },
      "port": 80,
      "enable_tag_override": false,
      "checks": {
        "name": "HTTP 2",
        "http": "http://localhost:4200/",
        "method": "GET",
        "interval": "10s",
        "timeout": "1s"
      },
      "token": "233b604b-b92e-48c8-a253-5f11514e4b50",
    }
  }