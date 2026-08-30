# Reflex — Person 4 Trade-off Log

## 1. Hive-based offline delivery queue

### Weak point
Retailer requests created offline are stored locally and retried when connectivity returns. A connectivity signal does not guarantee that the backend is actually reachable.

There is also an ambiguous network-failure case where the server may create a delivery but the client loses the response and retries it later.

### Acceptable because
The MVP needs basic offline resilience without the complexity of a complete distributed synchronization system.

### Future fix
Add client-generated idempotency keys and backend deduplication so retries cannot create duplicate deliveries.

---

## 2. Manual rider assignment

### Weak point
The Dispatcher manually selects a rider. This becomes inefficient as rider and delivery volumes increase and does not account for location or rider workload.

### Acceptable because
Reflex targets relatively small retailer delivery teams, so manual assignment is appropriate for the MVP.

### Future fix
Add rider availability, workload and geographic data, then implement intelligent rider matching.

---

## 3. Socket.IO events trigger REST refreshes

### Weak point
Flutter uses delivery:assigned and delivery:updated as refresh signals instead of treating their partial payloads as complete Delivery state.

This creates an additional HTTP request.

### Acceptable because
The REST backend remains the source of truth, which reduces the risk of incomplete or stale client state.

### Future fix
Introduce versioned full-state socket events, reconnection reconciliation and event replay.

---

## Key takeaway
The MVP favors correctness, resilience and simple integration over advanced routing and distributed synchronization.