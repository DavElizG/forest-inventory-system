export default function Dashboard() {
  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold text-gray-900 mb-6">Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-gray-500 text-sm font-medium">Total Árboles</h3>
          <p className="text-3xl font-bold text-gray-900 mt-2">1,234</p>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-gray-500 text-sm font-medium">Parcelas</h3>
          <p className="text-3xl font-bold text-gray-900 mt-2">45</p>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-gray-500 text-sm font-medium">Especies</h3>
          <p className="text-3xl font-bold text-gray-900 mt-2">89</p>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-gray-500 text-sm font-medium">Usuarios</h3>
          <p className="text-3xl font-bold text-gray-900 mt-2">12</p>
        </div>
      </div>
      <p className="mt-8 text-gray-600">TODO: Implementar gráficos y estadísticas</p>
    </div>
  );
}
