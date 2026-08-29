import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Delivery, DeliveryDocument, DeliveryStatus } from '../schemas/delivery.schema';
import { CreateDeliveryDto } from './dto/create-delivery.dto';
import { AssignDeliveryDto } from '.src/deliveries/dto/assign-delivery.dto.ts';

@Injectable()
export class DeliveriesService {
  constructor(
    @InjectModel(Delivery.name) private deliveryModel: Model<DeliveryDocument>,
  ) {}

  async create(dto: CreateDeliveryDto): Promise<Delivery> {
    return this.deliveryModel.create({
      retailerId: new Types.ObjectId(dto.retailerId),
      pickupAddress: dto.pickupAddress,
      dropoffAddress: dto.dropoffAddress,
    });
  }

  async findForRetailer(retailerId: string): Promise<Delivery[]> {
    if (!Types.ObjectId.isValid(retailerId)) {
      throw new BadRequestException('retailerId is not a valid id');
    }
    return this.deliveryModel.find({ retailerId }).sort({ createdAt: -1 });
  }

  async assign(id: string, dto: AssignDeliveryDto): Promise<Delivery> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('delivery id is not valid');
    }
    const delivery = await this.deliveryModel.findById(id);
    if (!delivery) {
      throw new NotFoundException('delivery not found');
    }
    if (delivery.status !== DeliveryStatus.PENDING) {
      throw new ConflictException(
        `delivery is already ${delivery.status}, cannot assign`,
      );
    }
    delivery.riderId = new Types.ObjectId(dto.riderId);
    delivery.status = DeliveryStatus.ASSIGNED;
    return delivery.save();
  }
}