# q08 — Move an HTTP Ingress to an HTTPRoute

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `blog`, Ingress `blog` publishes host `blog.example.com`: path `/` goes to
Service `blog` on port `80`, and path `/api` goes to Service `blog-api` on port `8080`.
The platform team runs Gateway `public-gw` in namespace `gateway`. Its listener `http`
(protocol HTTP, port 80) accepts routes from all namespaces. Service `blog` answers every
request with `blog-web`, Service `blog-api` answers every request with `blog-api`.

1. Create HTTPRoute `blog` in namespace `blog`, attached to listener `http` of Gateway
   `public-gw` in namespace `gateway`, with the same hostname and the same two path rules
   as Ingress `blog`.
2. Using the address of Gateway `public-gw` and the header `Host: blog.example.com`,
   verify that `/` reaches `blog` and `/api` reaches `blog-api`.
3. After the verification succeeds, delete Ingress `blog`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
