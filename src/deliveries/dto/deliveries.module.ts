import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import {
  Delivery,
  DeliverySchema,
} from '../../schemas/delivery.schema';
import { DeliveriesController } from './deliveries.controller';
import { DeliveriesService } from './deliveries.service';
import { DeliveryGateway } from '../delivery.gateway';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Delivery.name, schema: DeliverySchema },
    ]),
  ],
  controllers: [DeliveriesController],
  providers: [DeliveriesService, DeliveryGateway],
  exports: [DeliveriesService, DeliveryGateway],
})
export class DeliveriesModule {}
