export default {
  fetch(request: Request): Response {
    const { pathname } = new URL(request.url);

    if (pathname !== '/health') {
      return new Response(null, { status: 404 });
    }

    if (request.method !== 'GET') {
      return new Response(null, {
        status: 405,
        headers: { Allow: 'GET' },
      });
    }

    return Response.json({ status: 'ok' });
  },
};
