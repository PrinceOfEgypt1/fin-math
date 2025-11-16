// packages/api/src/services/snapshot.service.ts
import { createHash, randomUUID } from "crypto";

/**
 * Interface para Snapshot armazenado
 */
interface Snapshot {
  id: string;
  hash: string;
  input: any;
  output: any;
  meta: {
    motorVersion: string;
    timestamp: string;
    endpoint: string;
  };
}

/**
 * Service para gestão de snapshots
 */
class SnapshotService {
  private snapshots: Map<string, Snapshot> = new Map();
  private readonly motorVersion = "0.2.0";

  /**
   * Cria novo snapshot
   */
  create(input: any, output: any, endpoint: string): Snapshot {
    const id = randomUUID();
    const hash = this.generateHash(input, output);
    const timestamp = new Date().toISOString();

    const snapshot: Snapshot = {
      id,
      hash,
      input,
      output,
      meta: {
        motorVersion: this.motorVersion,
        timestamp,
        endpoint,
      },
    };

    this.snapshots.set(id, snapshot);
    return snapshot;
  }

  /**
   * Recupera snapshot por ID
   */
  get(id: string): Snapshot | undefined {
    return this.snapshots.get(id);
  }

  /**
   * Gera hash SHA-256 do snapshot
   */
  private generateHash(input: any, output: any): string {
    const data = JSON.stringify({ input, output });
    return createHash("sha256").update(data).digest("hex");
  }
}

export const snapshotService = new SnapshotService();
