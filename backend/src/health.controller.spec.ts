import { ServiceUnavailableException } from '@nestjs/common';
import { DatabaseService } from './database.service';
import { HealthController } from './health.controller';

describe('HealthController', () => {
  it('reports database failures without exposing connection details', async () => {
    const database = { ping: jest.fn().mockRejectedValue(new Error('private credentials')) };
    const controller = new HealthController(database as unknown as DatabaseService);
    await expect(controller.databaseHealth()).rejects.toThrow(ServiceUnavailableException);
    await expect(controller.databaseHealth()).rejects.toThrow('Database unavailable');
  });
});
