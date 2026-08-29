import { IsMongoId, IsNotEmpty, IsString } from 'class-validator';

export class CreateDeliveryDto {
  @IsMongoId()
  retailerId: string;

  @IsString()
  @IsNotEmpty()
  pickupAddress: string;

  @IsString()
  @IsNotEmpty()
  dropoffAddress: string;
}