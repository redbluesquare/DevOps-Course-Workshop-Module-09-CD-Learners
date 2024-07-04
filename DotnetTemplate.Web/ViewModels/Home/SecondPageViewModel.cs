namespace DotnetTemplate.Web.ViewModels.Home
{
    using System.Collections.Generic;

    public class SecondPageViewModel
    {
        public readonly IEnumerable<string> SecondPageItems;

        public SecondPageViewModel()
        {
            SecondPageItems = new[]
            {
                "Second Page Item 1",
                "Second Page Item 2",
                "Book: The Phoenix Project"
            };
        }
    }
}
