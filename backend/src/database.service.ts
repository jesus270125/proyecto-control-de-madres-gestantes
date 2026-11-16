import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { createPool, Pool } from 'mysql2/promise';

@Injectable()
export class DatabaseService implements OnModuleDestroy {
  private pool?: Pool;

  async ping(): Promise<void> {
    if (!this.pool) {
      const { DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME } = process.env;
      if (!DB_HOST || !DB_USER || !DB_PASSWORD || !DB_NAME) {
        throw new Error('Database configuration is incomplete');
      }
      this.pool = createPool({ host: DB_HOST, port: Number(DB_PORT || 3306), user: DB_USER,
        password: DB_PASSWORD, database: DB_NAME, connectionLimit: 2, connectTimeout: 5000 });
    }
    await this.pool.query('SELECT 1');
  }

  async onModuleDestroy(): Promise<void> {
    await this.pool?.end();
  }
}
