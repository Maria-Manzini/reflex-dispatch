import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  Delivery,
  DeliveryDocument,
  DeliveryStatus,
} from '../../schemas/delivery.schema';
import { CreateDeliveryDto } from './create-delivery.dto';
import { AssignDeliveryDto } from './assign-delivery.dto';
import { DeliveryGateway } from '../delivery.gateway';

@Injectable()
export class DeliveriesService {
  constructor(
    @InjectModel(Delivery.name)
    private deliveryModel: Model<DeliveryDocument>,
    private deliveryGateway: DeliveryGateway,
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
    return this.deliveryModel
      .find({ retailerId })
      .sort({ createdAt: -1 });
  }

  async getOpen(): Promise<Delivery[]> {
    return this.deliveryModel
      .find({ status: DeliveryStatus.PENDING })
      .sort({ createdAt: -1 });
  }

  async assign(id: string, dto: AssignDeliveryDto): Promise<Delivery> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('delivery id is not valid');
    }
    if (!Types.ObjectId.isValid(dto.riderId)) {
      throw new BadRequestException('riderId is not valid');
    }

    const updated = await this.deliveryModel.findOneAndUpdate(
      {
        _id: new Types.ObjectId(id),
        status: DeliveryStatus.PENDING,
      },
      {
        $set: {
          riderId: new Types.ObjectId(dto.riderId),
          status: DeliveryStatus.ASSIGNED,
        },
      },
      { new: true },
    );

    if (!updated) {
      const exists = await this.deliveryModel.findById(id);
      if (!exists) {
        throw new NotFoundException('delivery not found');
      }
      throw new ConflictException(
        `delivery is already ${exists.status}, cannot assign`,
      );
    }

    this.deliveryGateway.emitDeliveryAssigned({
      deliveryId: updated._id.toString(),
      riderId: dto.riderId,
      pickupAddress: updated.pickupAddress,
      dropoffAddress: updated.dropoffAddress,
      status: updated.status,
      assignedAt: new Date().toISOString(),
    });

    return updated;
  }
}
