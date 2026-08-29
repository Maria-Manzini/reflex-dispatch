import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { DeliveriesService } from './deliveries.service';
import { CreateDeliveryDto } from './create-delivery.dto';
import { AssignDeliveryDto } from './assign-delivery.dto';

@Controller('deliveries')
export class DeliveriesController {
  constructor(
    private readonly deliveriesService: DeliveriesService,
  ) {}

  @Post()
  create(@Body() dto: CreateDeliveryDto) {
    return this.deliveriesService.create(dto);
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
}
