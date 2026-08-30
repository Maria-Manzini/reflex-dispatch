# Reflex — Person 4 Demo Script

I will demonstrate the Retailer and Dispatcher parts of Reflex.

First, as the Retailer, I open My Requests and select New Delivery.

The form captures customer name, phone number, delivery address and item description.

When online, submitting sends the request to POST /deliveries and the request appears with the status Created.

The Retailer screen listens for delivery:assigned and delivery:updated Socket.IO events. The events trigger a REST refresh so the application displays the latest authoritative delivery state.

If the Retailer creates a request while offline, it is stored locally in Hive and displayed as Pending Sync. When connectivity returns, the application retries the pending request and removes it from Hive after successful synchronization.

Next, as the Dispatcher, I open Open Deliveries. This calls GET /deliveries?status=open.

For an open delivery, I select a rider from the Assign dropdown and choose Assign Rider.

Flutter calls PATCH /deliveries/:id/assign with the selected riderId.

Person 2's backend performs the assignment atomically. If another dispatcher already assigned the delivery, the backend returns 409 Conflict instead of overwriting the existing assignment.

After assignment, delivery:assigned is emitted and the Rider can continue Person 3's flow from Assigned to Picked Up and finally Delivered after QR confirmation.

The main Person 4 trade-off is the offline queue. Hive provides useful resilience, but the MVP does not yet implement idempotency keys. A future version would add client-generated request IDs and backend deduplication to make retries safe.