import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type DeliveryDocument = HydratedDocument<Delivery>;

export enum DeliveryStatus {
  PENDING = 'pending',
  ASSIGNED = 'assigned',
  IN_TRANSIT = 'in_transit',
  DELIVERED = 'delivered',
}

@Schema({ timestamps: { createdAt: true, updatedAt: false } })
export class Delivery {
  @Prop({ type: Types.ObjectId, ref: 'Retailer', required: true })
  retailerId: Types.ObjectId;

  @Prop({ required: true })
  pickupAddress: string;

  @Prop({ required: true })
  dropoffAddress: string;

  @Prop({
    type: String,
    enum: DeliveryStatus,
    default: DeliveryStatus.PENDING,
  })
  status: DeliveryStatus;

  @Prop({ type: Types.ObjectId, ref: 'Rider', default: null })
  riderId: Types.ObjectId | null;
}

export const DeliverySchema = SchemaFactory.createForClass(Delivery);