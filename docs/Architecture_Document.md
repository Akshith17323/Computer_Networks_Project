# Architecture Document

## Machine Roles and IP / Service Table

| Machine | Owner | Primary Role | IP Address | Services Running |
|---------|-------|--------------|------------|------------------|
| **Mac 1** | Friend | Private DNS Server & Test Client | `10.16.13.239` | dnsmasq, curl |
| **Mac 2** | Akshith | Edge / Reverse Proxy & Load Balancer | `10.16.13.1` | nginx, TLS (443) |
| **Mac 3** | Mohit | Backend Server A | `10.16.13.37` | Node.js / Express (3001) |
| **Mac 4** | Jayadeep | Backend Server B | `10.16.13.71` | Node.js / Express (3002) |

## Network Topology Diagram
```mermaid
flowchart LR
    subgraph LAN [Team Nucleus Private LAN]
        direction LR
        
        subgraph Mac1 [Mac 1 - Friend]
            Client(Test Client curl)
            DNS(Private DNS Server dnsmasq)
        end

        subgraph Mac2 [Mac 2 - Akshith]
            Edge(Edge Load Balancer Nginx 10.16.13.1)
        end

        subgraph Mac3 [Mac 3 - Mohit]
            BackendA(Backend Server A 10.16.13.37)
        end

        subgraph Mac4 [Mac 4 - Jayadeep]
            BackendB(Backend Server B 10.16.13.71)
        end

        %% Connections
        Client -.->|1. DNS Query UDP 53| DNS
        DNS -.->|2. Returns 10.16.13.1| Client
        
        Client == 3. HTTPS Request TCP 443 ==> Edge
        
        Edge -->|4a. Proxy TCP 3001| BackendA
        Edge -->|4b. Proxy TCP 3002| BackendB
    end
```

## Request-Flow Diagram showing each protocol layer
```mermaid
sequenceDiagram
    participant Client
    participant DNS
    participant Nginx
    participant Backend

    Note over Client, DNS: Layer 7 (Application): DNS over Layer 4 (UDP Port 53)
    Client->>DNS: Query app.team1.test
    DNS-->>Client: 10.16.13.1

    Note over Client, Nginx: Layer 4 (Transport): TCP 3-Way Handshake
    Client->>Nginx: SYN
    Nginx-->>Client: SYN-ACK
    Client->>Nginx: ACK

    Note over Client, Nginx: Layer 5/6 (Session/Presentation): TLS Handshake
    Client->>Nginx: ClientHello
    Nginx-->>Client: ServerHello, Certificate
    Client->>Nginx: ChangeCipherSpec, Finished

    Note over Client, Nginx: Layer 7 (Application): HTTP/1.1
    Client->>Nginx: GET /api/status (Encrypted)
    
    Note over Nginx, Backend: Layer 7 (HTTP) over TCP
    Nginx->>Backend: Forward GET request
    Backend-->>Nginx: 200 OK (JSON)
    Nginx-->>Client: 200 OK (Encrypted)
```
