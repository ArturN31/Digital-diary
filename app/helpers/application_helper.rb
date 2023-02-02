module ApplicationHelper
    #Changes active navbar element
    def current_class?(test_path)
        return 'nav-link active' if request.path == test_path
        'nav-link'
    end
end
