import { IsMongoId } from 'class-validator';

export class AssignDeliveryDto {
  @IsMongoId()
  riderId!: string;
}