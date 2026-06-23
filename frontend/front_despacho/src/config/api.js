// En EKS el navegador entra al servicio LoadBalancer del frontend.
// Nginx dentro del frontend redirige estas rutas a los Services internos:
// /api/v1/ventas    -> backend-ventas:8080
// /api/v1/despachos -> backend-despachos:8081

export const VENTAS_API = import.meta.env.VITE_VENTAS_API_URL || "/api/v1/ventas";
export const DESPACHOS_API = import.meta.env.VITE_DESPACHOS_API_URL || "/api/v1/despachos";