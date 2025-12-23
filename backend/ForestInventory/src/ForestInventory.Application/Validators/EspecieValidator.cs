using FluentValidation;
using ForestInventory.Application.DTOs;

namespace ForestInventory.Application.Validators;

public class CreateEspecieDtoValidator : AbstractValidator<CreateEspecieDto>
{
    public CreateEspecieDtoValidator()
    {
        RuleFor(x => x.NombreComun)
            .NotEmpty().WithMessage("El nombre común es requerido")
            .MaximumLength(200).WithMessage("El nombre común no puede exceder 200 caracteres")
            .Matches(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").WithMessage("El nombre común solo puede contener letras y espacios");

        RuleFor(x => x.NombreCientifico)
            .NotEmpty().WithMessage("El nombre científico es requerido")
            .MaximumLength(200).WithMessage("El nombre científico no puede exceder 200 caracteres")
            .Matches(@"^[a-zA-Z\s]+$").WithMessage("El nombre científico solo puede contener letras latinas y espacios");

        RuleFor(x => x.Familia)
            .MaximumLength(100).WithMessage("La familia no puede exceder 100 caracteres")
            .When(x => !string.IsNullOrEmpty(x.Familia));

        RuleFor(x => x.Descripcion)
            .MaximumLength(1000).WithMessage("La descripción no puede exceder 1000 caracteres")
            .When(x => !string.IsNullOrEmpty(x.Descripcion));

        RuleFor(x => x.DensidadMadera)
            .GreaterThan(0).WithMessage("La densidad de la madera debe ser mayor a 0")
            .LessThanOrEqualTo(2000).WithMessage("La densidad de la madera no puede exceder 2000 kg/m³")
            .When(x => x.DensidadMadera.HasValue);
    }
}

public class UpdateEspecieDtoValidator : AbstractValidator<UpdateEspecieDto>
{
    public UpdateEspecieDtoValidator()
    {
        RuleFor(x => x.NombreComun)
            .NotEmpty().WithMessage("El nombre común es requerido")
            .MaximumLength(200).WithMessage("El nombre común no puede exceder 200 caracteres")
            .Matches(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").WithMessage("El nombre común solo puede contener letras y espacios")
            .When(x => !string.IsNullOrEmpty(x.NombreComun));

        RuleFor(x => x.NombreCientifico)
            .NotEmpty().WithMessage("El nombre científico es requerido")
            .MaximumLength(200).WithMessage("El nombre científico no puede exceder 200 caracteres")
            .Matches(@"^[a-zA-Z\s]+$").WithMessage("El nombre científico solo puede contener letras latinas y espacios")
            .When(x => !string.IsNullOrEmpty(x.NombreCientifico));

        RuleFor(x => x.Familia)
            .MaximumLength(100).WithMessage("La familia no puede exceder 100 caracteres")
            .When(x => !string.IsNullOrEmpty(x.Familia));

        RuleFor(x => x.Descripcion)
            .MaximumLength(1000).WithMessage("La descripción no puede exceder 1000 caracteres")
            .When(x => !string.IsNullOrEmpty(x.Descripcion));

        RuleFor(x => x.DensidadMadera)
            .GreaterThan(0).WithMessage("La densidad de la madera debe ser mayor a 0")
            .LessThanOrEqualTo(2000).WithMessage("La densidad de la madera no puede exceder 2000 kg/m³")
            .When(x => x.DensidadMadera.HasValue);
    }
}
