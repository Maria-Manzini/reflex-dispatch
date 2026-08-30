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
import { UpdateDeliveryStatusDto } from './update-delivery-status.dto';

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

  async getMyDeliveries(
    riderId: string,
  ): Promise<Delivery[]> {
    if (!Types.ObjectId.isValid(riderId)) {
      throw new BadRequestException(
        'riderId is not a valid id',
      );
    }

    return this.deliveryModel
      .find({
        riderId: new Types.ObjectId(riderId),
      })
      .sort({ createdAt: -1 });
  }

  async updateRiderStatus(
    id: string,
    riderId: string,
    dto: UpdateDeliveryStatusDto,
  ): Promise<Delivery> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException(
        'delivery id is not valid',
      );
    }

    if (!Types.ObjectId.isValid(riderId)) {
      throw new BadRequestException(
        'riderId is not a valid id',
      );
    }

    let requiredCurrentStatus: DeliveryStatus;

    if (dto.status === DeliveryStatus.IN_TRANSIT) {
      requiredCurrentStatus = DeliveryStatus.ASSIGNED;
    } else if (dto.status === DeliveryStatus.DELIVERED) {
      requiredCurrentStatus = DeliveryStatus.IN_TRANSIT;
    } else {
      throw new BadRequestException(
        'Rider can only update a delivery to in_transit or delivered',
      );
    }

    if (
      dto.status === DeliveryStatus.DELIVERED &&
      (!dto.scanCode || dto.scanCode.trim().length === 0)
    ) {
      throw new BadRequestException(
        'scanCode is required to complete delivery',
      );
    }

    const update: Record<string, unknown> = {
      status: dto.status,
    };

    if (dto.status === DeliveryStatus.DELIVERED) {
      update.proofScan = dto.scanCode!.trim();
    }

    const updated = await this.deliveryModel.findOneAndUpdate(
      {
        _id: new Types.ObjectId(id),
        riderId: new Types.ObjectId(riderId),
        status: requiredCurrentStatus,
      },
      {
        $set: update,
      },
      {
        new: true,
      },
    );

    if (!updated) {
      const delivery = await this.deliveryModel.findById(id);

      if (!delivery) {
        throw new NotFoundException(
          'delivery not found',
        );
      }

      if (
        !delivery.riderId ||
        delivery.riderId.toString() !== riderId
      ) {
        throw new NotFoundException(
          'delivery not found for this rider',
        );
      }

      throw new ConflictException(
        `invalid status transition: ${delivery.status} -> ${dto.status}`,
      );
    }

    this.deliveryGateway.emitDeliveryUpdated({
      deliveryId: updated._id.toString(),
      status: updated.status,
      updatedAt:
        (
          updated.get('updatedAt') as Date | undefined
        )?.toISOString() ?? new Date().toISOString(),
    });

    return updated;
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
      customerName: updated.get('customerName') as string,
      address: updated.get('address') as string,
      item: updated.get('item') as string,
      pickupAddress: updated.pickupAddress,
      dropoffAddress: updated.dropoffAddress,
      status: updated.status,
      assignedAt: new Date().toISOString(),
    });

    return updated;
  }
}
