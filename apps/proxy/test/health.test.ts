import { describe, expect, it } from 'vitest';

import worker from '../src/index';

describe('Worker health', () => {
  it('mengembalikan JSON status ok untuk GET /health', async () => {
    const response = worker.fetch(new Request('https://example.test/health'));

    expect(response.status).toBe(200);
    expect(response.headers.get('content-type')).toContain('application/json');
    expect(await response.json()).toEqual({ status: 'ok' });
  });

  it.each(['POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS'])(
    'menolak method %s pada /health',
    (method) => {
      const response = worker.fetch(
        new Request('https://example.test/health', { method }),
      );

      expect(response.status).toBe(405);
      expect(response.headers.get('allow')).toBe('GET');
    },
  );

  it.each(['/', '/chat', '/health/'])(
    'mengembalikan 404 untuk path %s',
    (path) => {
      const response = worker.fetch(new Request(`https://example.test${path}`));

      expect(response.status).toBe(404);
    },
  );
});
