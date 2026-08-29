import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({ cors: { origin: '*' } })
export class DeliveryGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  handleConnection(client: Socket) {
    console.log(`[Socket] Connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`[Socket] Disconnected: ${client.id}`);
  }

  emitDeliveryAssigned(payload: {
    deliveryId: string;
    riderId: string;
    customerName: string;
    address: string;
    item: string;
    pickupAddress: string;
    dropoffAddress: string;
    status: string;
    assignedAt: string;
  }) {
    this.server.emit('delivery:assigned', {
      event: 'delivery:assigned',
      data: payload,
    });
    console.log(
      `[Socket] delivery:assigned emitted - ${payload.deliveryId}`,
    );
  }

  emitDeliveryUpdated(payload: {
    deliveryId: string;
    status: string;
    updatedAt: string;
  }) {
    this.server.emit('delivery:updated', {
      event: 'delivery:updated',
      data: payload,
    });
  }
}
