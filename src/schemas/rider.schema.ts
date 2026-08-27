import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type RiderDocument = HydratedDocument<Rider>;

@Schema({ timestamps: true })
export class Rider {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true })
  phone: string;

  @Prop({ default: true })
  isAvailable: boolean;
}

export const RiderSchema = SchemaFactory.createForClass(Rider);