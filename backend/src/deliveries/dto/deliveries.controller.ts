import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UnauthorizedException,
} from '@nestjs/common';
import { Request } from 'express';

import { DeliveriesService } from './deliveries.service';
import { CreateDeliveryDto } from './create-delivery.dto';
import { AssignDeliveryDto } from './assign-delivery.dto';
import { UpdateDeliveryStatusDto } from './update-delivery-status.dto';

type AuthenticatedRequest = Request & {
  user?: {
    sub?: string;
    _id?: string;
    role?: string;
  };
};

@Controller('deliveries')
export class DeliveriesController {
  constructor(
    private readonly deliveriesService: DeliveriesService,
  ) {}

  @Post()
  create(@Body() dto: CreateDeliveryDto) {
    return this.deliveriesService.create(dto);
  }

  @Get('my')
  getMyDeliveries(@Req() req: AuthenticatedRequest) {
    const riderId = req.user?._id ?? req.user?.sub;

    if (!riderId) {
      throw new UnauthorizedException(
        'Authenticated rider is required',
      );
    }

    return this.deliveriesService.getMyDeliveries(riderId);
  }

  @Get()
  findAll(
    @Query('retailerId') retailerId: string,
    @Query('status') status: string,
  ) {
    if (status === 'open') {
      return this.deliveriesService.getOpen();
    }
    return this.deliveriesService.findForRetailer(retailerId);
  }

  @Patch(':id/assign')
  assign(
    @Param('id') id: string,
    @Body() dto: AssignDeliveryDto,
  ) {
    return this.deliveriesService.assign(id, dto);
  }

  @Patch(':id/status')
  updateStatus(
    @Param('id') id: string,
    @Body() dto: UpdateDeliveryStatusDto,
    @Req() req: AuthenticatedRequest,
  ) {
    const riderId = req.user?._id ?? req.user?.sub;

    if (!riderId) {
      throw new UnauthorizedException(
        'Authenticated rider is required',
      );
    }

    return this.deliveriesService.updateRiderStatus(
      id,
      riderId,
      dto,
    );
  }
}
