namespace DotnetTemplate.Web.ViewModels.Home
{
    using System.Collections.Generic;

    public class FirstPageViewModel
    {
        public readonly IEnumerable<string> FirstPageItems;

        public FirstPageViewModel()
        {
            FirstPageItems = new[]
            {
                "Book: The Phoenix Project",
                "Item 2",
                "Item 3"
            };
        }
    }
}
