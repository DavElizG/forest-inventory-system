using AutoMapper;
using ForestInventory.Application.DTOs;
using ForestInventory.Domain.Entities;
using ForestInventory.Domain.Enums;

namespace ForestInventory.Application.Mappings;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // Usuario mappings
        CreateMap<Usuario, UsuarioDto>()
            .ForMember(dest => dest.Rol, opt => opt.MapFrom(src => (int)src.Rol));
        CreateMap<CreateUsuarioDto, Usuario>()
            .ForMember(dest => dest.PasswordHash, opt => opt.MapFrom(src => src.Password))
            .ForMember(dest => dest.Rol, opt => opt.MapFrom(src => (RolUsuario)src.Rol))
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
            .ForMember(dest => dest.UltimoAcceso, opt => opt.Ignore())
            .ForMember(dest => dest.Activo, opt => opt.Ignore());

        // Arbol mappings
        CreateMap<Arbol, ArbolDto>()
            .ForMember(dest => dest.Diametro, opt => opt.MapFrom(src => src.Dap))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Observaciones))
            .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Sincronizado));
        CreateMap<CreateArbolDto, Arbol>()
            .ForMember(dest => dest.Dap, opt => opt.MapFrom(src => src.Diametro ?? 0))
            .ForMember(dest => dest.Observaciones, opt => opt.MapFrom(src => src.Descripcion))
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.Codigo, opt => opt.Ignore())
            .ForMember(dest => dest.Altitud, opt => opt.Ignore())
            .ForMember(dest => dest.AlturaComercial, opt => opt.Ignore())
            .ForMember(dest => dest.DiametroCopa, opt => opt.Ignore())
            .ForMember(dest => dest.Estado, opt => opt.Ignore())
            .ForMember(dest => dest.FechaMedicion, opt => opt.Ignore())
            .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
            .ForMember(dest => dest.FechaUltimaActualizacion, opt => opt.Ignore())
            .ForMember(dest => dest.Sincronizado, opt => opt.Ignore())
            .ForMember(dest => dest.SyncId, opt => opt.Ignore())
            .ForMember(dest => dest.UsuarioCreadorId, opt => opt.Ignore())
            .ForMember(dest => dest.Parcela, opt => opt.Ignore())
            .ForMember(dest => dest.Especie, opt => opt.Ignore())
            .ForMember(dest => dest.UsuarioCreador, opt => opt.Ignore());

        // Parcela mappings
        CreateMap<Parcela, ParcelaDto>();
        CreateMap<CreateParcelaDto, Parcela>()
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
            .ForMember(dest => dest.FechaUltimaActualizacion, opt => opt.Ignore())
            .ForMember(dest => dest.Activo, opt => opt.Ignore())
            .ForMember(dest => dest.UsuarioCreador, opt => opt.Ignore())
            .ForMember(dest => dest.Arboles, opt => opt.Ignore());

        // Especie mappings
        CreateMap<Especie, EspecieDto>();
        CreateMap<CreateEspecieDto, Especie>()
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
            .ForMember(dest => dest.Activo, opt => opt.Ignore())
            .ForMember(dest => dest.Arboles, opt => opt.Ignore());

        // SyncLog mappings
        CreateMap<SyncLog, SyncLogDto>()
            .ForMember(dest => dest.DispositivoId, opt => opt.MapFrom(src => src.UsuarioId.ToString()));
        CreateMap<CreateSyncLogDto, SyncLog>()
            .ForMember(dest => dest.UsuarioId, opt => opt.MapFrom(src => Guid.Parse(src.DispositivoId)))
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.FechaSincronizacion, opt => opt.Ignore())
            .ForMember(dest => dest.Usuario, opt => opt.Ignore());
    }
}
