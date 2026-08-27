import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type RetailerDocument = HydratedDocument<Retailer>;

@Schema({ timestamps: true })
export class Retailer {
  @Prop({ required: true })
  shopName: string;

  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  email: string;

  @Prop({ required: true })
  passwordHash: string;
}

export const RetailerSchema = SchemaFactory.createForClass(Retailer);